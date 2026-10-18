package com.sstinterview.models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.UUID;

@Entity
@Getter
@Setter
public class Experience extends BaseModel
{
    @Column(nullable = false)
    private UUID userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ExperienceStatus status = ExperienceStatus.PENDING;

    /** The "how it went" narrative. Questions live in {@link ExperienceQuestion}. */
    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(columnDefinition = "TEXT")
    private String advice;

    @ManyToOne
    @JoinColumn(nullable = false)
    private Company company;

    @ManyToMany
    @JoinTable(
            name = "experience_tags",
            joinColumns = @JoinColumn(name = "experience_id"),
            inverseJoinColumns = @JoinColumn(name = "tag_id")
    )
    private List<Tag> tags;

    @ManyToOne
    @JoinColumn(nullable = true)
    private RoundType roundType;

    @Column(nullable = false)
    private int roundNumber;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private Difficulty difficulty;

    @Enumerated(EnumType.STRING)
    @Column(name = "duration_bucket", length = 20)
    private DurationBucket durationBucket;
}
