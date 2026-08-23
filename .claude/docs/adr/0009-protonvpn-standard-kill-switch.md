# ADR 0009 - ProtonVPN with standard kill switch

## Status

Accepted

## Context

A VPN is required to cover all machine traffic across platforms. Two kill switch modes are available:

**Standard kill switch** - blocks internet traffic if the VPN tunnel drops, but LAN traffic (192.168.x.x) remains accessible.

**Permanent kill switch** - blocks all traffic including LAN if the VPN tunnel drops.

Permanent kill switch was considered but rejected because it breaks local development workflows: LAN-hosted services, local network mounts, and printer/NAS access all go dark when the VPN drops momentarily.

Browser-level VPN exit node switching (different exit IPs per browser profile) was also evaluated. The ProtonVPN Firefox extension is a controller for the OS-level daemon, not an independent tunnel - per-profile exit nodes are not achievable without manual server switching. Browser-level isolation (separate browser profiles) is the primary separation mechanism between identities; shared exit IP is accepted given ProtonVPN's large shared IP pool.

## Decision

Install **ProtonVPN** declaratively via nix with the **standard kill switch** enabled. All machine traffic routes through the VPN. LAN traffic is permitted through the kill switch to preserve local dev workflows.

## Consequences

- All browser profiles share the same VPN exit IP - identity separation relies on browser-level isolation, not network-level isolation
- LAN services remain accessible when the VPN tunnel drops
- ProtonVPN is installed on macOS and Linux via nix; Windows via winget
