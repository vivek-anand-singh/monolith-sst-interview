package com.sstinterview.util;

import com.sstinterview.models.Role;

public class RoleUtils {

    public static boolean hasAtLeast(String userRole, Role required) {
        try {
            return Role.valueOf(userRole).ordinal() >= required.ordinal();
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
}
