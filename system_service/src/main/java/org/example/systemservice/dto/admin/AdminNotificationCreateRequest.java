package org.example.systemservice.dto.admin;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class AdminNotificationCreateRequest {

    @NotBlank(message = "通知标题不能为空")
    @Size(max = 255, message = "通知标题不能超过255字符")
    private String title;

    @NotBlank(message = "通知渠道不能为空")
    private String channel;

    @NotBlank(message = "接收范围不能为空")
    private String audience;

    @Size(max = 1000, message = "通知内容不能超过1000字符")
    private String content;

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getChannel() {
        return channel;
    }

    public void setChannel(String channel) {
        this.channel = channel;
    }

    public String getAudience() {
        return audience;
    }

    public void setAudience(String audience) {
        this.audience = audience;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
