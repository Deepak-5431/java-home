package com.commander.industryhub.server.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;
import org.hibernate.validator.constraints.URL;
import lombok.Data;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDate;

@Data
public class UpdateProfileRequest {
    @NotBlank(message = "now now dont leave it blank")
    @Size(min=1,message = "atleast use a single char name right")
    private String  displayName;

    @Size(min=10,max = 300, message = "200 char should work its bio ")
    private String bio;

    @URL(message = "Avatar must be a valid URL")
    private String avatarUrl;

    private String location;

    @URL(message = "Website must be a valid URL")
    private String website;

    @Past(message = "Date of birth must be in the past")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private LocalDate dateOfBirth;
}
