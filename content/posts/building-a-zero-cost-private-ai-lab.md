---
title: "Building a Zero-Cost Private AI Lab on Consumer Hardware"
date: 2026-05-24
draft: false
tags: ["homelab", "ai", "proxmox", "gpu-passthrough", "docker", "privacy"]
categories: ["Lab Build"]
summary: "How I built a fully self-hosted AI inference environment with GPU passthrough, hardened containers, and zero-trust edge access — on hardware you can buy at Micro Center."
ShowToc: true
TocOpen: false
---

Every managed AI service wants your data on their servers. For security research, that's a non-starter.

I needed an environment where I could feed sensitive assets — firewall syslogs, vulnerability maps, proprietary scripts — into large language models without any of it leaving my physical control. No API calls to OpenAI. No data residency questions. No compliance gray areas.

So I built one.

This post walks through the full architecture: bare-metal hypervisor, GPU passthrough, containerized inference stack, and zero-trust edge access. Total cloud hosting cost: **$0/month**.

The "What Broke" section is the one that would have saved me hours if someone else had written it first.

## The Hardware

The core constraint was fitting meaningful local inference into a consumer budget. The build:

- **CPU:** AMD Ryzen 7 (8c/16t) — enough cores to dedicate 6 to the AI VM while the hypervisor keeps the rest
- **RAM:** 32GB DDR4 — 20GB allocated to the AI VM, the rest to the hypervisor and ancillary VMs
- **GPU:** NVIDIA RTX-class card, 16GB VRAM — sufficient for quantized 13B models and most 7B models at full precision
- **Storage:** 1TB NVMe for the OS/VM images, 2TB SATA SSD for model weights

The GPU VRAM is the real constraint. 16GB lets you run a quantized Llama 3 70B at Q4, or most 13B models comfortably. If you're budgeting, the single most impactful upgrade you can make to a homelab inference rig is more VRAM.

Everything here is off-the-shelf consumer hardware. Nothing exotic. The software does the work.

## Phase 1: Hypervisor and Firmware

**Ventoy first.** Before touching BIOS settings, I set up a Ventoy USB drive with the Proxmox installer. Ventoy lets you boot multiple ISOs from a single drive — invaluable when you're iterating through different hypervisor versions or have to reinstall.

**BIOS/UEFI prerequisites for GPU passthrough:**

The passthrough path requires hardware-level support for IOMMU (AMD-Vi on AMD, VT-d on Intel). Before the Proxmox installer boots, you need to enable:

- SVM Mode (AMD) or Intel Virtualization Technology
- IOMMU (AMD-Vi / Intel VT-d)
- Above 4G Decoding
- Re-Size BAR Support (if your board supports it — helps with newer NVIDIA cards)

On most boards these are buried under "Advanced CPU Configuration" or "AMD CBS." If they're missing from your BIOS, a firmware update often surfaces them.

**Proxmox install** is straightforward once the BIOS is configured. Use the graphical installer, put the OS on the NVMe, and set a static IP during setup. Post-install, edit `/etc/apt/sources.list` to use the community repo instead of the enterprise repo (the enterprise repo requires a paid subscription):

```bash
# /etc/apt/sources.list.d/pve-no-subscription.list
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
```

Then comment out the enterprise repo in `/etc/apt/sources.list.d/pve-enterprise.list`.

**Enable IOMMU in the bootloader.** After install, add `amd_iommu=on iommu=pt` (or `intel_iommu=on iommu=pt`) to your GRUB kernel parameters in `/etc/default/grub`:

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on iommu=pt"
```

Run `update-grub` and reboot. Verify IOMMU groups are populating:

```bash
find /sys/kernel/iommu_groups/ -type l | sort -V
```

If you see output, you're in business. If the GPU and its audio device are in the same IOMMU group and nothing else is in that group, you're ready for passthrough.

## Phase 2: GPU Passthrough

This is the section everyone Googles and nobody explains well. Here's the condensed version of what actually matters.

**Machine type: q35.** When creating the VM in Proxmox, use the q35 machine type with OVMF (UEFI) firmware — not SeaBIOS. q35 is required for PCIe passthrough to work correctly with modern NVIDIA cards.

**Blacklist the GPU on the host.** Proxmox (the host) must not load NVIDIA drivers for the card you're passing through. If the host claims the GPU, the VM can't have it. Add these to `/etc/modprobe.d/blacklist.conf`:

```
blacklist nouveau
blacklist nvidia
blacklist nvidiafb
```

Then bind the GPU to the `vfio-pci` driver instead:

```
# /etc/modprobe.d/vfio.conf
options vfio-pci ids=XXXX:XXXX,XXXX:XXXX
```

Replace the IDs with your GPU's PCI vendor:device IDs — find them with `lspci -nn | grep NVIDIA`. You need both the GPU ID and the HDMI audio ID.

Add `vfio vfio_iommu_type1 vfio_pci vfio_virqfd` to `/etc/modules`, run `update-initramfs -u -k all`, and reboot.

**In the Proxmox VM config**, add the GPU as a PCI device with "All Functions" checked and "ROM-Bar" enabled. For NVIDIA cards, also set `x-vga=1` if you're passing through the primary GPU.

**Inside the VM**, install NVIDIA drivers as you normally would. The VM sees the card as physical hardware. Run `nvidia-smi` to confirm it's visible and showing the correct VRAM.

One catch specific to NVIDIA consumer cards: some driver versions include code that detects when they're running in a hypervisor and intentionally fail (the infamous Error 43). The fix is to hide the hypervisor signature in the VM config by adding `kvm=off` and `hidden=1` to the CPU flags. Proxmox exposes this in the VM's hardware settings or directly in the `.conf` file:

```
cpu: host,hidden=1,flags=+pcid
args: -cpu 'host,+kvm_pv_unhalt,+kvm_pv_eoi,hv_vendor_id=NvidiaFTW,kvm=off'
```

## Phase 3: The Container Stack

With a working GPU VM running Ubuntu Server, the inference stack goes in as containers.

**Install Docker with NVIDIA support:**

```bash
# Docker
curl -fsSL https://get.docker.com | sh

# NVIDIA Container Toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
# ... (follow NVIDIA's current install docs for your distro)

sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

Verify GPU access from a container:

```bash
docker run --rm --gpus all nvidia/cuda:12-base-ubuntu22.04 nvidia-smi
```

If that shows your GPU, the container runtime is wired up correctly.

**The compose stack.** The core services:

```yaml
services:
  ollama:
    image: ollama/ollama
    runtime: nvidia
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
    volumes:
      - ollama_data:/root/.ollama
    ports:
      - "11434:11434"
    restart: unless-stopped

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    environment:
      - OLLAMA_BASE_URL=http://host.docker.internal:11434
    extra_hosts:
      - "host.docker.internal:host-gateway"
    volumes:
      - open_webui_data:/app/backend/data
    ports:
      - "3000:8080"
    restart: unless-stopped

volumes:
  ollama_data:
  open_webui_data:
```

Pull a model and test:

```bash
docker exec -it ollama ollama pull llama3
```

Open WebUI at `http://localhost:3000` should show the model in the selector and inference should be running on the GPU.

## What Broke (And How I Fixed It)

This is the section that would have saved me hours.

### The LVM Trap

Ubuntu Server's default installer allocates roughly 50% of the disk to the root logical volume, even if you tell it to use the whole drive. The rest sits in the volume group, allocated but unused.

I discovered this the hard way when Docker ran out of space pulling a 20GB model file. `df -h` showed 40GB used on a 50GB filesystem when there was a 500GB drive in the machine.

The fix:

```bash
# Find your volume group and free space
vgdisplay
lvdisplay

# Extend the logical volume to use all free space
lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv

# Resize the filesystem to match
resize2fs /dev/ubuntu-vg/ubuntu-lv
```

Verify with `df -h`. This should now show the full disk capacity available.

### The OOM Killer

Running large models against 16GB of RAM in the VM was tight. The OOM killer started terminating processes mid-inference — specifically targeting `ollama serve` when another workload was active simultaneously.

Two fixes:

First, expand swap significantly. The default Ubuntu swap is undersized for inference workloads:

```bash
# Disable current swap
sudo swapoff -a

# Create a 12GB swapfile
sudo fallocate -l 12G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make it persistent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

Second, I had Stable Diffusion running in the stack alongside Ollama. The WebUI for Stable Diffusion was keeping the AUTOMATIC1111 process warm, which held a large chunk of VRAM even when idle. Unloading it — `docker compose stop stable-diffusion` — gave Ollama the headroom it needed for larger models.

If you're primarily doing LLM inference rather than image generation, don't run both simultaneously unless you have the VRAM budget for it.

### Docker's File Descriptor Ceiling

This one cost me a full evening.

I was ingesting SonicWall syslog data through a Python script piped into the inference stack — high-volume log events, each opening a connection. The script would run for a few minutes, then the container would crash with a cryptic error.

The actual problem: Docker containers inherit a default `ulimit` of 1024 open file descriptors. High-volume syslog ingestion blows through that ceiling fast.

Fix in `/etc/docker/daemon.json`:

```json
{
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 65536,
      "Soft": 65536
    }
  }
}
```

Restart Docker. Verify the new limit from inside a running container:

```bash
docker exec -it <container> sh -c "ulimit -n"
```

Should show 65536. The syslog ingestion stopped crashing.

### The Localhost Loop

Open WebUI couldn't reach Ollama.

The symptom: Open WebUI loaded, models showed in the selector, but every inference request returned a connection error. Ollama was running fine when tested directly via `curl`.

The problem: the default `OLLAMA_BASE_URL` in many Open WebUI docs is set to `http://localhost:11434`. Inside a Docker container, `localhost` refers to the container itself — not the host machine where Ollama is listening.

The fix is `host.docker.internal`, a DNS name Docker provides for exactly this purpose. Two things required:

1. Set `OLLAMA_BASE_URL=http://host.docker.internal:11434` in the Open WebUI environment
2. Add `extra_hosts: ["host.docker.internal:host-gateway"]` to the Open WebUI service definition (Linux Docker doesn't resolve this by default — macOS and Windows Docker Desktop do)

Both are in the compose snippet above. If you're copying configs from older tutorials, this is likely what's broken.

## Edge Access Without Open Ports

The inference stack runs on a machine on my local network. I need to reach it from outside — from a laptop, a remote workstation, wherever — without exposing any ports to the internet.

The solution is Cloudflare Zero Trust Tunnel. It's free for personal use, requires no port forwarding on the router, and creates an encrypted tunnel from the Cloudflare edge directly to the container.

Setup is about ten minutes:

1. Create a Cloudflare Zero Trust account at `one.dash.cloudflare.com`
2. Go to Networks → Tunnels → Create a tunnel
3. Install `cloudflared` on the VM and run the connector command Cloudflare provides
4. Add a public hostname pointing to `localhost:3000` (or wherever Open WebUI is listening)
5. Set an Access policy (email OTP or a short list of allowed emails) so only you can reach it

The result: Open WebUI is accessible at `https://your-subdomain.your-domain.com`, sessions are encrypted end-to-end, there are no open ports on your router, and the access log lives in Cloudflare's dashboard.

For a lab handling sensitive research data, this is the right architecture. The inference never leaves the hardware; only the session traffic passes through the tunnel.

## What's Next

Three things on the near-term roadmap:

**LiteLLM gateway.** Right now Ollama is the only inference backend. LiteLLM sits in front of multiple backends — Ollama, vLLM, remote APIs — and presents a unified OpenAI-compatible endpoint. That means switching between local and remote models becomes a config change, not a code change.

**Isolated attack range.** A separate VM network for intentionally vulnerable targets — the kind of environment you need to test detection logic, run offensive tooling, or validate that your LLM-assisted analysis is actually catching what it should. Air-gapped from the inference stack.

**SSO consolidation.** Right now each service has its own auth. Open WebUI, SearXNG, and any future tools should all sit behind a single identity provider — likely Authentik or Authelia — so access management is centralized and auditable.

---

*This is the first post in a series documenting the wwwombat lab. Next: GPU passthrough on Proxmox in depth — the IOMMU groups, the Error 43 workarounds, and the parts of the documentation that are quietly wrong.*
