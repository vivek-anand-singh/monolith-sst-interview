package com.sstinterview.controller;

import com.sstinterview.dto.response.NotificationResponseDto;
import com.sstinterview.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/notifications")
@Tag(name = "Notifications", description = "Fetch in-app notifications for users and admins")
public class NotificationController
{
    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService)
    {
        this.notificationService = notificationService;
    }

    @Operation(summary = "Get my notifications", description = "Returns all notifications for the logged-in user, newest first")
    @GetMapping("/me")
    public ResponseEntity<List<NotificationResponseDto>> getMyNotifications(@RequestHeader("X-User-Id") UUID userId)
    {
        return ResponseEntity.ok(notificationService.getMyNotifications(userId));
    }

    @Operation(summary = "Mark a notification as read")
    @PatchMapping("/me/{id}/read")
    public ResponseEntity<NotificationResponseDto> markAsRead(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable UUID id)
    {
        return ResponseEntity.ok(notificationService.markAsRead(userId, id));
    }

    @Operation(summary = "Get flagged post notifications", description = "Admin only — returns all experience flagged notifications")
    @GetMapping("/admin")
    public ResponseEntity<List<NotificationResponseDto>> getAdminNotifications(@RequestHeader("X-User-Role") String userRole)
    {
        return ResponseEntity.ok(notificationService.getAdminNotifications(userRole));
    }
}
