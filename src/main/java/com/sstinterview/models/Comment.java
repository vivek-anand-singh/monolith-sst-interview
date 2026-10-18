package com.sstinterview.models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Entity
@Getter
@Setter
// Comments are rendered sorted by time descending on the frontend.
public class Comment extends BaseModel
{
    @Column(nullable = false)
    private UUID userId;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String message;

    @ManyToOne
    @JoinColumn(nullable = false)
    private Experience experience;
}
