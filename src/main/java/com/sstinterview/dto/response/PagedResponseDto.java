package com.sstinterview.dto.response;

import lombok.Getter;
import lombok.Setter;
import org.springframework.data.domain.Page;

import java.util.List;
import java.util.function.Function;
import java.util.stream.Collectors;

@Getter
@Setter
public class PagedResponseDto<T> {

    private List<T> content;
    private int page;
    private int size;
    private long totalElements;
    private int totalPages;

    public static <E, D> PagedResponseDto<D> from(Page<E> pageResult, Function<E, D> mapper) {
        PagedResponseDto<D> dto = new PagedResponseDto<>();
        dto.setContent(pageResult.getContent().stream().map(mapper).collect(Collectors.toList()));
        dto.setPage(pageResult.getNumber());
        dto.setSize(pageResult.getSize());
        dto.setTotalElements(pageResult.getTotalElements());
        dto.setTotalPages(pageResult.getTotalPages());
        return dto;
    }

    public static <T> PagedResponseDto<T> of(List<T> content, int page, int size, long totalElements, int totalPages) {
        PagedResponseDto<T> dto = new PagedResponseDto<>();
        dto.setContent(content);
        dto.setPage(page);
        dto.setSize(size);
        dto.setTotalElements(totalElements);
        dto.setTotalPages(totalPages);
        return dto;
    }
}
