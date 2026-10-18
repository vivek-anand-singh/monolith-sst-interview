package com.sstinterview.service;

import com.sstinterview.models.ExperienceStatus;
import com.sstinterview.models.Notification;
import com.sstinterview.models.NotificationType;
import com.sstinterview.repository.NotificationRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class NotificationServiceImplTest
{
    @Mock
    private NotificationRepository notificationRepository;

    @Mock
    private UserService userService;

    @InjectMocks
    private NotificationServiceImpl notificationService;

    @Test
    void notificationFailureNeverFailsTheCaller()
    {
        when(userService.getAdminIds()).thenThrow(new IllegalStateException("db down"));

        assertDoesNotThrow(() -> notificationService.notifyExperienceSubmitted(UUID.randomUUID(), "Acme"));
    }

    @Test
    void submittedExperienceNotifiesEveryAdmin()
    {
        List<UUID> adminIds = List.of(UUID.randomUUID(), UUID.randomUUID());
        when(userService.getAdminIds()).thenReturn(adminIds);

        notificationService.notifyExperienceSubmitted(UUID.randomUUID(), "Acme");

        ArgumentCaptor<Notification> saved = ArgumentCaptor.forClass(Notification.class);
        verify(notificationRepository, org.mockito.Mockito.times(2)).save(saved.capture());
        assertEquals(adminIds, saved.getAllValues().stream().map(Notification::getRecipientUserId).toList());
        assertTrue(saved.getAllValues().stream().allMatch(n -> n.getType() == NotificationType.EXPERIENCE_SUBMITTED));
    }

    @Test
    void noAdminsMeansNothingIsSaved()
    {
        when(userService.getAdminIds()).thenReturn(List.of());

        notificationService.notifyExperienceSubmitted(UUID.randomUUID(), "Acme");

        verify(notificationRepository, never()).save(any());
    }

    @Test
    void rejectionMessageCarriesTheFeedback()
    {
        UUID author = UUID.randomUUID();

        notificationService.notifyExperienceReviewed(UUID.randomUUID(), author, ExperienceStatus.REJECTED, "Too vague", "Acme");

        ArgumentCaptor<Notification> saved = ArgumentCaptor.forClass(Notification.class);
        verify(notificationRepository).save(saved.capture());
        assertEquals(NotificationType.EXPERIENCE_REJECTED, saved.getValue().getType());
        assertEquals(author, saved.getValue().getRecipientUserId());
        assertTrue(saved.getValue().getMessage().contains("Too vague"));
    }

    @Test
    void userCannotMarkSomeoneElsesNotificationAsRead()
    {
        UUID notificationId = UUID.randomUUID();
        Notification notification = new Notification();
        notification.setRecipientUserId(UUID.randomUUID());
        when(notificationRepository.findById(notificationId)).thenReturn(Optional.of(notification));

        assertThrows(SecurityException.class, () -> notificationService.markAsRead(UUID.randomUUID(), notificationId));
        verify(notificationRepository, never()).save(any());
    }

    @Test
    void onlyAdminsSeeFlaggedNotifications()
    {
        assertThrows(SecurityException.class, () -> notificationService.getAdminNotifications("USER"));
    }
}
