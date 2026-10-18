package com.sstinterview.dto.response;

import com.sstinterview.models.Difficulty;
import com.sstinterview.models.DurationBucket;
import com.sstinterview.models.Experience;
import com.sstinterview.models.ExperienceStatus;
import com.sstinterview.models.Tag;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
public class ExperienceResponseDto {

    private UUID id;
    /** The "how it went" narrative only — questions and advice are their own fields. */
    private String content;
    private String advice;
    private int roundNumber;
    private String roundType;
    private UUID roundTypeId;
    private String company;
    private UUID companyId;
    private List<String> tags;
    /**
     * The same tags as ids. Needed by the edit form: names alone cannot restore a
     * selection, and without it an edit would silently clear every tag on the post.
     */
    private List<UUID> tagIds;
    private UUID userId;
    private String authorName;
    private Instant createdAt;
    private long commentsCount;
    private ExperienceStatus status;
    private Difficulty difficulty;
    private DurationBucket durationBucket;

    /** Questions asked, in author order. Populated on list and detail responses alike. */
    private List<String> questions = new ArrayList<>();

    private int questionsCount;

    public static ExperienceResponseDto from(Experience experience, String authorName) {
        return from(experience, authorName, 0L, List.of());
    }

    public static ExperienceResponseDto from(Experience experience, String authorName, long commentsCount) {
        return from(experience, authorName, commentsCount, List.of());
    }

    public static ExperienceResponseDto from(Experience experience,
                                             String authorName,
                                             long commentsCount,
                                             List<String> questions) {
        ExperienceResponseDto dto = new ExperienceResponseDto();
        dto.setId(experience.getId());
        dto.setContent(experience.getContent());
        dto.setAdvice(experience.getAdvice());
        dto.setRoundNumber(experience.getRoundNumber());
        if (experience.getRoundType() != null) {
            dto.setRoundType(experience.getRoundType().getName());
            dto.setRoundTypeId(experience.getRoundType().getId());
        }
        dto.setCompany(experience.getCompany().getName());
        dto.setCompanyId(experience.getCompany().getId());
        dto.setUserId(experience.getUserId());
        dto.setAuthorName(authorName);
        dto.setCreatedAt(experience.getCreatedAt());
        dto.setCommentsCount(commentsCount);
        dto.setStatus(experience.getStatus());
        dto.setDifficulty(experience.getDifficulty());
        dto.setDurationBucket(experience.getDurationBucket());

        List<String> safeQuestions = questions != null ? new ArrayList<>(questions) : new ArrayList<>();
        dto.setQuestions(safeQuestions);
        dto.setQuestionsCount(safeQuestions.size());

        List<String> tagNames = new ArrayList<>();
        List<UUID> tagIds = new ArrayList<>();
        if (experience.getTags() != null) {
            for (Tag tag : experience.getTags()) {
                tagNames.add(tag.getName());
                tagIds.add(tag.getId());
            }
        }
        dto.setTags(tagNames);
        dto.setTagIds(tagIds);

        return dto;
    }
}
