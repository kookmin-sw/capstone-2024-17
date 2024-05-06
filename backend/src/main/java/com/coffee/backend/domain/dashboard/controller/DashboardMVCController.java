package com.coffee.backend.domain.dashboard.controller;

import com.coffee.backend.domain.company.dto.CompanyRequestDto;
import com.coffee.backend.domain.company.service.CompanyRequestService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Slf4j
@RequiredArgsConstructor
@Controller
public class DashboardMVCController {
    private final CompanyRequestService companyRequestService;

    @GetMapping("/dashboard")
    public String dashboard(Model model, @RequestParam(required = false, defaultValue = "0") int page) {
        Page<CompanyRequestDto> paging = companyRequestService.findAllRequests(page);
        model.addAttribute("paging", paging);
        return "dashboard/index";
    }
}
