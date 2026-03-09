package com.healthcare.tracemeds.config;

import com.sap.cds.services.request.UserInfo;
import org.springframework.stereotype.Component;

import java.util.Optional;

/**
 * Security utilities for getting current user information
 */
@Component
public class SecurityConfig {

    private final UserInfo userInfo;

    public SecurityConfig(UserInfo userInfo) {
        this.userInfo = userInfo;
    }

    /**
     * Get current user's name
     */
    public String getCurrentUser() {
        return Optional.ofNullable(userInfo.getName())
                .orElse("anonymous");
    }

    /**
     * Check if user has specific role
     */
    public boolean hasRole(String role) {
        return userInfo.hasRole(role);
    }

    /**
     * Get hospital ID from user attributes (for hospital users)
     */
    public Optional<String> getCurrentHospitalID() {
        return userInfo.getAttributeValues("HospitalID")
                .stream()
                .findFirst();
    }

    /**
     * Get supplier ID from user attributes (for supplier users)
     */
    public Optional<String> getCurrentSupplierID() {
        return userInfo.getAttributeValues("SupplierID")
                .stream()
                .findFirst();
    }

    /**
     * Check if user is System Admin
     */
    public boolean isSystemAdmin() {
        return hasRole("SystemAdmin");
    }

    /**
     * Check if user is Hospital User
     */
    public boolean isHospitalUser() {
        return hasRole("HospitalUser");
    }

    /**
     * Check if user is Procurement Officer
     */
    public boolean isProcurementOfficer() {
        return hasRole("ProcurementOfficer");
    }
}