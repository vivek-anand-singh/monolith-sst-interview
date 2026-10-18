package com.sstinterview.models;

import jakarta.persistence.Entity;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class RoundType extends BaseModel
{
    private String name;
}
