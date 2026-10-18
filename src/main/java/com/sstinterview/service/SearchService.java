package com.sstinterview.service;

import com.sstinterview.dto.response.SearchResultDto;

public interface SearchService {

    SearchResultDto search(String query, int page, int size);
}
