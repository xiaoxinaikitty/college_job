package org.example.systemservice.repository;

import org.example.systemservice.entity.Conversation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ConversationRepository extends JpaRepository<Conversation, Long> {

    Optional<Conversation> findByApplicationId(Long applicationId);

    Optional<Conversation> findByIdAndStudentUserId(Long id, Long studentUserId);

    List<Conversation> findByStudentUserIdOrderByUpdatedAtDesc(Long studentUserId);
}
