/**
 * CSOpsBypass — csops get-task-allow bypass for Dopamine rootless
 *
 * Hooks csops() and csops_audittoken() to strip CS_GET_TASK_ALLOW
 * and CS_DEBUGGED flags from the code signing status returned to
 * the calling process. This prevents jailbreak detection that relies
 * on code signing flag (csops) queries.
 */

#import <substrate.h>
#import <dlfcn.h>
#import <stdint.h>
#import <sys/types.h>

// --- Code signing flag constants (from bsd/sys/codesign.h) ---
#define CS_VALID           0x00000001
#define CS_GET_TASK_ALLOW  0x00000004
#define CS_DEBUGGED        0x00000100

// csops operations
#define CS_OPS_STATUS      0
#define CS_OPS_CDHASH      5

// ============================================================
// MARK: - csops hook
// ============================================================

static int (*orig_csops)(pid_t pid, unsigned int ops,
                         void *useraddr, size_t usersize);

static int hooked_csops(pid_t pid, unsigned int ops,
                        void *useraddr, size_t usersize) {
    int result = orig_csops(pid, ops, useraddr, usersize);

    if (result == 0 && useraddr != NULL &&
        ops == CS_OPS_STATUS && usersize >= sizeof(uint32_t)) {
        uint32_t *flags = (uint32_t *)useraddr;
        *flags &= ~(CS_GET_TASK_ALLOW | CS_DEBUGGED);
        *flags |= CS_VALID;
    }

    return result;
}

// ============================================================
// MARK: - csops_audittoken hook
// ============================================================

static int (*orig_csops_audittoken)(pid_t pid, unsigned int ops,
                                    void *useraddr, size_t usersize,
                                    audit_token_t *token);

static int hooked_csops_audittoken(pid_t pid, unsigned int ops,
                                   void *useraddr, size_t usersize,
                                   audit_token_t *token) {
    int result = orig_csops_audittoken(pid, ops, useraddr, usersize, token);

    if (result == 0 && useraddr != NULL &&
        ops == CS_OPS_STATUS && usersize >= sizeof(uint32_t)) {
        uint32_t *flags = (uint32_t *)useraddr;
        *flags &= ~(CS_GET_TASK_ALLOW | CS_DEBUGGED);
        *flags |= CS_VALID;
    }

    return result;
}

// ============================================================
// MARK: - Constructor — install hooks at dylib load time
// ============================================================

__attribute__((constructor))
static void CSOpsBypass_init(void) {
    // Hook csops — resolve from libsystem_kernel via dlsym
    void *sym_csops = dlsym(RTLD_DEFAULT, "csops");
    if (sym_csops) {
        MSHookFunction(sym_csops,
                       (void *)hooked_csops,
                       (void **)&orig_csops);
    }

    // Hook csops_audittoken
    void *sym_csops_at = dlsym(RTLD_DEFAULT, "csops_audittoken");
    if (sym_csops_at) {
        MSHookFunction(sym_csops_at,
                       (void *)hooked_csops_audittoken,
                       (void **)&orig_csops_audittoken);
    }
}
