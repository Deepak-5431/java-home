package com.commander.industryhub.server.user.dto;

import com.commander.industryhub.server.user.model.UserRole;
import com.commander.industryhub.server.user.model.UserStatus;
import lombok.Data;
import java.time.Instant;

@Data
public class UserDto {
    private long id;
    private String username;
    private UserRole role;
    private UserStatus status;
    private Instant createdAt;
    private Instant updatedAt;
    private Instant lastLoginAt;
}
