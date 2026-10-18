package com.sstinterview.models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Entity
@Getter
@Setter
public class Tag extends BaseModel
{
    @Column(nullable = false, unique = true)
    private String name;

    @ManyToMany(mappedBy = "tags")
    private List<Company> companies;

    @ManyToMany(mappedBy = "tags")
    private List<Experience> experiences;
}
