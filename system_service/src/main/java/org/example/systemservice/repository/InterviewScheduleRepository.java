package org.example.systemservice.repository;

import org.example.systemservice.entity.InterviewSchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface InterviewScheduleRepository extends JpaRepository<InterviewSchedule, Long> {

    @Query("""
            select i from InterviewSchedule i
            where i.applicationId in (
              select a.id from JobApplication a where a.studentUserId = :studentUserId
            )
            order by i.scheduledAt desc
            """)
    List<InterviewSchedule> findByStudentUserId(@Param("studentUserId") Long studentUserId);
}
