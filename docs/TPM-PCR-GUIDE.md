# TPM PCR Considerations for Framework NixOS

## Overview

This document explains why TPM enrollment must be handled carefully when using ISO installations and how PCR (Platform Configuration Register) values affect the process.

## What are PCRs?

Platform Configuration Registers (PCRs) are secure storage locations in the TPM that contain cryptographic hashes of system components:

- **PCR 0**: Core Root of Trust for Measurement (CRTM), BIOS, Host Platform Extensions
- **PCR 1**: Host Platform Configuration  
- **PCR 2**: Option ROM Code
- **PCR 3**: Option ROM Configuration and Data
- **PCR 4**: IPL (Initial Program Loader) Code (usually boot loader)
- **PCR 5**: IPL Config and Data (boot loader configuration)
- **PCR 6**: State Transition and Wake Events
- **PCR 7**: Secure Boot Policy (critical for our setup)
- **PCR 8-15**: Used by operating systems

## PCR 7 and Secure Boot

PCR 7 contains measurements of:
- Secure Boot state
- Secure Boot policy 
- Boot certificates and signatures
- UEFI variables related to Secure Boot

**Critical Issue**: PCR 7 values are DIFFERENT between:
- ✅ **Live ISO environment** (temporary, installer certificates)
- ✅ **Installed system** (permanent, lanzaboote certificates)

## Why This Matters for TPM LUKS

When we enroll TPM for LUKS unlocking:

1. **TPM records current PCR values** (including PCR 7)
2. **On boot, TPM checks PCR values** against recorded ones
3. **If PCR values don't match, TPM refuses to unlock**
4. **System cannot boot** (LUKS remains locked)

## Our Solution

### ISO Configuration
- **Excludes TPM module** - prevents accidental enrollment
- **No lanzaboote** - different boot certificates
- **Clear warnings** in installation scripts
- **Detection scripts** to prevent enrollment from wrong environment

### Installation Process
1. **Boot from ISO** (PCR 7 = ISO certificates)
2. **Install NixOS** with lanzaboote + TPM modules
3. **Reboot** into installed system (PCR 7 = lanzaboote certificates)
4. **Enroll TPM** from installed system (correct PCR 7 values)

### Safety Checks

Our `tpm-enroll.sh` script includes:
- **Environment detection** - refuses to run from installer
- **NixOS validation** - ensures proper installation
- **Clear warnings** about PCR importance

## PCR Policy We Use

```bash
systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 "$LUKS_DEVICE"
```

This uses:
- **PCR 0**: Core boot measurements (firmware)
- **PCR 7**: Secure Boot policy (our lanzaboote setup)

## What Happens If You Mess This Up

**Scenario**: Enroll TPM from live ISO

1. TPM records PCR 7 with ISO certificate values
2. Reboot into installed system
3. PCR 7 now has lanzaboote certificate values (different!)
4. TPM refuses to unlock LUKS
5. System cannot boot - password required every time
6. Need to re-enroll TPM or recover with password

## Recovery Process

If TPM enrollment was done incorrectly:

1. **Boot with password** (LUKS fallback)
2. **Remove bad TPM enrollment**:
   ```bash
   sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/your-luks-device
   ```
3. **Re-enroll correctly**:
   ```bash
   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/your-luks-device
   ```

## Best Practices

### For ISO Building
- ✅ Never include TPM enrollment in ISO
- ✅ Include TPM tools for post-install use
- ✅ Clear documentation about timing
- ✅ Safety checks in scripts

### For Installation
- ✅ Complete installation first
- ✅ Reboot into installed system
- ✅ Verify Secure Boot is working
- ✅ Then enroll TPM

### For Updates
- ✅ Kernel updates usually don't affect PCR 7
- ✅ Bootloader updates might require re-enrollment
- ✅ Always keep LUKS password as backup
- ✅ Test TPM unlock after major updates

## Testing TPM Enrollment

After enrollment, test the setup:

1. **Verify enrollment**:
   ```bash
   sudo systemd-cryptenroll /dev/your-luks-device
   ```

2. **Test unlock** (careful!):
   ```bash
   sudo reboot
   # System should unlock automatically
   ```

3. **If it doesn't work**:
   - Boot with password
   - Check PCR values: `sudo tpm2_pcrread`
   - Re-enroll if needed

## Monitoring PCR Values

View current PCR values:
```bash
# All PCRs
sudo tpm2_pcrread

# Specific PCRs
sudo tpm2_pcrread sha256:0,7
```

Compare with enrolled values:
```bash
sudo systemd-cryptenroll /dev/your-luks-device
```

## Framework-Specific Notes

Framework laptops have:
- ✅ **Reliable TPM 2.0** - good for enrollment
- ✅ **UEFI Secure Boot** - affects PCR 7
- ✅ **Firmware updates** - may require re-enrollment
- ✅ **BIOS settings** - changes can affect PCRs

## Conclusion

TPM enrollment timing is critical for security and functionality. Our configuration ensures:

1. **Safe ISO builds** without TPM conflicts
2. **Proper installation flow** with correct timing
3. **Recovery options** if things go wrong
4. **Clear documentation** to prevent mistakes

**Remember**: When in doubt, always keep your LUKS password as backup. TPM is convenient but not infallible!
