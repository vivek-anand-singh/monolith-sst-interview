package com.sstinterview.models;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

/**
 * One question asked in an interview round. Stored as its own row so the number
 * of questions is a queryable count rather than something parsed out of prose.
 */
@Entity
@Table(name = "experience_question")
@Getter
@Setter
public class ExperienceQuestion extends BaseModel
{
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "experience_id", nullable = false)
    private Experience experience;

    @Column(nullable = false)
    private int position;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String text;
}
