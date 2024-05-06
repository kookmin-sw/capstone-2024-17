package com.coffee.backend.domain.dashboard.controller;

import com.coffee.backend.domain.company.dto.CompanyRequestDto;
import com.coffee.backend.domain.company.service.CompanyRequestService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Slf4j
@RequiredArgsConstructor
@Controller
public class DashboardMVCController {
    private final CompanyRequestService companyRequestService;
    private final ModelMapper mapper;

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        List<CompanyRequestDto> requests = companyRequestService.findAllRequests();
        model.addAttribute("requests", requests);
        return "dashboard/index";
    }
}
