package com.commander.industryhub.server.user.dto;

import lombok.Data;
import java.time.Instant;

@Data
public class ProfileDto {
    private Long userId;
    private String displayName;
    private String bio;
    private String avatarUrl;
    private String location;
    private String website;
    private Instant dateOfBirth;
    private Integer followerCount;
    private Integer followingCount;
    private Instant createdAt;
    private Instant updatedAt;
}
