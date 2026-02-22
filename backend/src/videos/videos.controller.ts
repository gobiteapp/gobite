import { Controller, Get, Post, Patch, Param, Body, UseGuards } from '@nestjs/common';
import { VideosService } from './videos.service';
import { AuthGuard } from '../auth/auth.guard';
import { VideoSource } from '@prisma/client';

@Controller('videos')
export class VideosController {
  constructor(private readonly videosService: VideosService) {}

  @Get('restaurant/:restaurantId')
  findByRestaurant(@Param('restaurantId') restaurantId: string) {
    return this.videosService.findByRestaurant(restaurantId);
  }

  @Post()
  @UseGuards(AuthGuard)
  create(@Body() body: {
    restaurantId: string;
    source: VideoSource;
    tiktokUrl?: string;
    videoUrl?: string;
    creatorHandle?: string;
  }) {
    return this.videosService.create(body.restaurantId, body);
  }

  @Patch(':id/approve')
  @UseGuards(AuthGuard)
  approve(@Param('id') id: string) {
    return this.videosService.approve(id);
  }

  @Patch(':id/reject')
  @UseGuards(AuthGuard)
  reject(@Param('id') id: string) {
    return this.videosService.reject(id);
  }
}