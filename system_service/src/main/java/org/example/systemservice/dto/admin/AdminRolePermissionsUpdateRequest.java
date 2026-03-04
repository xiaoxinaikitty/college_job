package org.example.systemservice.dto.admin;

import jakarta.validation.constraints.NotNull;

import java.util.List;

public class AdminRolePermissionsUpdateRequest {

    @NotNull(message = "权限列表不能为空")
    private List<String> permissions;

    public List<String> getPermissions() {
        return permissions;
    }

    public void setPermissions(List<String> permissions) {
        this.permissions = permissions;
    }
}
