package com.sstinterview.models;

import com.sstinterview.models.Role;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import jakarta.persistence.CheckConstraint;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Getter
@Setter
@Table(
        name = "users",
        check = @CheckConstraint(
                name = "auth_fields_check",
                constraint = "(auth_type = 'PASSWORD' AND password_hash IS NOT NULL AND auth_provider_id IS NULL) " + "OR " + "(auth_type <> 'PASSWORD' AND password_hash IS NULL AND auth_provider_id IS NOT NULL)"
        )
)
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(nullable = false, updatable = false)
    private UUID id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AuthType authType;

    @Column
    private String passwordHash;

    @Column(unique = true)
    private String authProviderId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role = Role.USER;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private Instant updatedAt;
}