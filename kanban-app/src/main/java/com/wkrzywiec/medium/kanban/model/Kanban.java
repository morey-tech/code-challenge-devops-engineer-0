package com.wkrzywiec.medium.kanban.model;

import lombok.Data;

import java.util.List;

@Data
public class Kanban {

    private Long id;
    private String title;
    private List<Task> taskList;
}
