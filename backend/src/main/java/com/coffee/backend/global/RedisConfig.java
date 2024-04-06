package com.coffee.backend.global;

import com.coffee.backend.domain.redis.service.RedisService;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.listener.ChannelTopic;
import org.springframework.data.redis.listener.RedisMessageListenerContainer;
import org.springframework.data.redis.listener.adapter.MessageListenerAdapter;
import org.springframework.data.redis.serializer.Jackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;

@EnableCaching
@Configuration
public class RedisConfig {
    // Redis에 데이터 저장/검색하는데 사용
    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);
        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(new Jackson2JsonRedisSerializer<>(String.class));
        return template;
    }

    // 특정 토픽 구독해서 메시지 수신/처리할 수 있도록 설정
    @Bean
    RedisMessageListenerContainer container(RedisConnectionFactory connectionFactory,
                                            MessageListenerAdapter cafeChoiceListenerAdapter,
                                            MessageListenerAdapter matchRequestListenerAdapter) {

        RedisMessageListenerContainer container = new RedisMessageListenerContainer();
        container.setConnectionFactory(connectionFactory);
        container.addMessageListener(cafeChoiceListenerAdapter,
                new ChannelTopic("cafeChoice")); // PatternTopic 대신 ChannelTopic 사용
        container.addMessageListener(matchRequestListenerAdapter,
                new ChannelTopic("matchRequest"));
        return container;
    }

    // cafeChoice 토픽 메시지 수신/처리
    @Bean
    MessageListenerAdapter cafeChoiceListenerAdapter(RedisService redisService) {
        return new MessageListenerAdapter(redisService, "handleCafeChoice");
    }

    // matchRequest 토픽 메시지 수신/처리
    @Bean
    MessageListenerAdapter matchRequestListenerAdapter(RedisService redisService) {
        return new MessageListenerAdapter(redisService, "handleMatchRequest");
    }
}