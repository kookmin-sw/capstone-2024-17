package com.coffee.backend.global;

import com.coffee.backend.domain.redis.service.RedisService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.MessageListener;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.listener.ChannelTopic;
import org.springframework.data.redis.listener.RedisMessageListenerContainer;
import org.springframework.data.redis.listener.adapter.MessageListenerAdapter;
import org.springframework.data.redis.serializer.Jackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;

@Configuration
public class RedisConfig {
    @Bean
    public RedisConnectionFactory connectionFactory() {
        return new LettuceConnectionFactory();
    }

    @Bean
    public RedisTemplate<String, String> redisTemplate() {
        final RedisTemplate<String, String> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory());
        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(new Jackson2JsonRedisSerializer<>(String.class));
        return template;
    }

    // Redis 의 channel 로부터 메시지를 수신받아 해당 MessageListenerAdapter 에게 디스패치
    @Bean
    public RedisMessageListenerContainer container(MessageListenerAdapter cafeChoiceListenerAdapter,
                                                   MessageListenerAdapter matchRequestListenerAdapter
    ) {
        final RedisMessageListenerContainer container = new RedisMessageListenerContainer();

        container.setConnectionFactory(connectionFactory());
        container.addMessageListener(cafeChoiceListenerAdapter, cafeChoiceTopic());
        container.addMessageListener(matchRequestListenerAdapter, matchRequestTopic());

        return container;
    }

    @Bean
    public MessageListenerAdapter cafeChoiceListenerAdapter(RedisService redisService) {
        return new MessageListenerAdapter(redisService, "handleCafeChoice");
    }

    @Bean
    public MessageListenerAdapter matchRequestListenerAdapter(RedisService redisService) {
        return new MessageListenerAdapter(redisService, "handleMatchRequest");
    }

    @Bean
    public ChannelTopic cafeChoiceTopic() {
        return new ChannelTopic("cafeChoice");
    }

    @Bean
    public ChannelTopic matchRequestTopic() {
        return new ChannelTopic("matchRequest");
    }
}