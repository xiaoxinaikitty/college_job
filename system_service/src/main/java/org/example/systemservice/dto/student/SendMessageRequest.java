package org.example.systemservice.dto.student;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class SendMessageRequest {

    @NotNull(message = "消息类型不能为空")
    private Integer messageType;

    @Size(max = 1000, message = "消息内容过长")
    private String contentText;

    @Size(max = 512, message = "文件地址过长")
    private String fileUrl;

    public Integer getMessageType() {
        return messageType;
    }

    public void setMessageType(Integer messageType) {
        this.messageType = messageType;
    }

    public String getContentText() {
        return contentText;
    }

    public void setContentText(String contentText) {
        this.contentText = contentText;
    }

    public String getFileUrl() {
        return fileUrl;
    }

    public void setFileUrl(String fileUrl) {
        this.fileUrl = fileUrl;
    }
}
