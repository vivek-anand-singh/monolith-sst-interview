package com.sstinterview.models;

import jakarta.persistence.Entity;
import jakarta.persistence.ManyToOne;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Entity
@Getter
@Setter
// This replies in the frontend will be rendered on the basis of strictly sorted of time ascending .
public class Reply extends BaseModel
{
    private UUID userId;
    @ManyToOne
    private Comment comment;
    private String message;
}
