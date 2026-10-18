package com.sstinterview.util;

import com.sstinterview.models.Role;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RoleUtilsTest
{
    @Test
    void adminAndSuperadminSatisfyAdminRequirement()
    {
        assertTrue(RoleUtils.hasAtLeast("ADMIN", Role.ADMIN));
        assertTrue(RoleUtils.hasAtLeast("SUPERADMIN", Role.ADMIN));
    }

    @Test
    void plainUserDoesNotSatisfyAdminRequirement()
    {
        assertFalse(RoleUtils.hasAtLeast("USER", Role.ADMIN));
    }

    @Test
    void unknownRoleIsTreatedAsNoAccess()
    {
        assertFalse(RoleUtils.hasAtLeast("ROOT", Role.USER));
    }
}
