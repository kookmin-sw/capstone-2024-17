package com.coffee.backend.domain.dashboard.controller;

import com.coffee.backend.domain.company.dto.CompanyRequestDto;
import java.util.ArrayList;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
public class DashboardMVCController {
    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        List<CompanyRequestDto> requests = new ArrayList<>();
        requests.add(CompanyRequestDto.builder()
                .id(1L)
                .user("유저이름")
                .name("회사이름")
                .bno("000000088")
                .domain("google.com").build());
        model.addAttribute("requests", requests);
        return "dashboard/index";
    }
}
