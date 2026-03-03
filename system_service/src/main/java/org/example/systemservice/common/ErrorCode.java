package org.example.systemservice.common;

public final class ErrorCode {

    private ErrorCode() {
    }

    public static final int PARAM_ERROR = 4001;
    public static final int PHONE_ALREADY_EXISTS = 4002;
    public static final int USER_NOT_FOUND = 4003;
    public static final int PASSWORD_ERROR = 4004;
    public static final int ACCOUNT_DISABLED = 4005;
    public static final int USER_TYPE_MISMATCH = 4006;
    public static final int DATA_NOT_FOUND = 4007;
    public static final int JOB_NOT_ONLINE = 4008;
    public static final int RESUME_NOT_FOUND = 4009;
    public static final int ALREADY_APPLIED = 4010;
    public static final int OFFER_STATUS_INVALID = 4011;
    public static final int APPLICATION_STATUS_INVALID = 4012;
    public static final int SYSTEM_ERROR = 5000;
}
