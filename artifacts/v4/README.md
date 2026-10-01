# v4 Complete Handoff Archive

This archive exists so a future Codex / Claude Code / human implementation pass can recover the generated design/prototype history rather than only the latest cleaned spec.

## Archive

```text
complete_handoff/Surge_Wizard_v4_COMPLETE_HANDOFF_CONTENT_2026-10-01.tar.xz
```

SHA-256:

```text
1e3a7b89640377869b9598a92970bfd884a22aa08980d07067a9a76703101792
```

At handoff time **128 top-level generated Surge Wizard v4 artifacts** were present in the generation workspace.

The archive contains:
- exact copies of every top-level non-ZIP v4 artifact available at handoff time.
- extracted logical contents of every generated top-level ZIP package.
- latest extracted v3.5 spec/code working directories where available.
- the original artifact manifest with name, size, SHA-256 and type.

This covers historical master specifications, detailed-spec packages, campaign/world/quest/companion/economy/spell/enemy/boss specs, camera/layout proof PNGs, implementation reports, static-check outputs, simulation CSV/JSON, v2.9–v3.5 Flutter prototype package contents and v3.5 working snapshots.

## ZIP-container note

The original ZIP *container bytes* are not duplicated inside this archive. Their original name, byte size and SHA-256 are retained in the archive manifest, and their logical contents are extracted. This avoids filling the repository with many redundant compressed copies while retaining everything an implementation agent needs to inspect or reconstruct the work.

## Extract

```bash
mkdir -p /tmp/surge_v4_handoff
tar -xJf artifacts/v4/complete_handoff/Surge_Wizard_v4_COMPLETE_HANDOFF_CONTENT_2026-10-01.tar.xz \
  -C /tmp/surge_v4_handoff
```

Do not infer authority from file age. Read `AGENT_START_HERE.md`.
