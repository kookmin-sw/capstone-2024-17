package com.coffee.backend.utils;

import com.coffee.backend.domain.company.dto.CompanyDto;
import com.coffee.backend.domain.company.entity.Company;
import com.coffee.backend.domain.storage.service.StorageService;
import com.coffee.backend.domain.user.dto.UserDto;
import com.coffee.backend.domain.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class CustomMapper {
    private final ModelMapper mapper;
    private final StorageService storageService;

    public UserDto toUserDto(User user) {
        return mapper.typeMap(User.class, UserDto.class)
                .setPostConverter(context -> {
                    context.getDestination()
                            .setPosition(context.getSource().getPosition().getName());

                    Company company = context.getSource().getCompany();
                    if (company != null) {
                        var dto = toCompanyDto(company);
                        context.getDestination().setCompany(dto);
                    }
                    return context.getDestination();
                })
                .map(user);
    }

    public CompanyDto toCompanyDto(Company company) {
        if (company == null) {
            return CompanyDto.builder()
                    .name("무소속")
                    .domain(null)
                    .logoUrl(null)
                    .build();
        }

        return CompanyDto.builder()
                .name(company.getName())
                .domain(company.getDomain())
                .logoUrl(storageService.getFileUrl(company.getLogo().getStoredFilename())).build();
    }
}
