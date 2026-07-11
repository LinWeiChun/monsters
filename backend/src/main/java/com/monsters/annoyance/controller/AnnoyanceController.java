package com.monsters.annoyance.controller;

import com.monsters.annoyance.service.AnnoyanceService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/annoyances")
public class AnnoyanceController {

    private final AnnoyanceService annoyanceService;

    public AnnoyanceController(AnnoyanceService annoyanceService) {
        this.annoyanceService = annoyanceService;
    }
}
