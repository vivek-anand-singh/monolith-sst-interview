package com.sstinterview.models;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.ManyToOne;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

@Entity
@Getter
@Setter
public class Flag extends BaseModel
{
    private UUID userId;
    @ManyToOne
    private Experience experience;
    @ManyToOne
    private Comment comment;
    @ManyToOne
    private Reply reply;
    private UUID targetExperienceId;
    private String reason;
    @Enumerated(EnumType.STRING)
    private FlagStatus status = FlagStatus.PENDING;
    private UUID resolvedByUserId;
    private Instant resolvedAt;
}
