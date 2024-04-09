package com.coffee.backend.global;

import com.coffee.backend.domain.cafe.service.CafeSubscriber;
import com.coffee.backend.domain.match.service.MatchSubscriber;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.listener.ChannelTopic;
import org.springframework.data.redis.listener.RedisMessageListenerContainer;
import org.springframework.data.redis.listener.adapter.MessageListenerAdapter;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;

@Configuration
public class RedisConfig {
    @Bean
    public RedisConnectionFactory connectionFactory() {
        return new LettuceConnectionFactory();
    }

    @Bean
    public RedisTemplate<String, Object> redisTemplate() {
        final RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory());
        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(new GenericJackson2JsonRedisSerializer());
        return template;
    }

    // Redis의 channel로부터 메시지를 수신받아 해당 MessageListenerAdapter에게 dispatch
    @Bean
    public RedisMessageListenerContainer container(MessageListenerAdapter matchListenerAdapter,
                                                   MessageListenerAdapter cafeListenerAdapter) {
        final RedisMessageListenerContainer container = new RedisMessageListenerContainer();

        container.setConnectionFactory(connectionFactory());
        container.addMessageListener(matchListenerAdapter, topic01());
        container.addMessageListener(cafeListenerAdapter, topic02());

        return container;
    }

    @Bean
    public MessageListenerAdapter matchListenerAdapter(MatchSubscriber matchSubscriber) {
        return new MessageListenerAdapter(matchSubscriber, "onMessage");
    }

    @Bean
    public MessageListenerAdapter cafeListenerAdapter(CafeSubscriber cafeSubscriber) {
        return new MessageListenerAdapter(cafeSubscriber, "onMessage");
    }

    @Bean
    public ChannelTopic topic01() {
        return new ChannelTopic("matchRequest");
    }

    @Bean
    public ChannelTopic topic02() {
        return new ChannelTopic("cafeChoice");
    }
}