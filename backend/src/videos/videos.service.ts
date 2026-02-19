import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { VideoSource, VideoStatus } from '@prisma/client';

@Injectable()
export class VideosService {
  constructor(private prisma: PrismaService) {}

  async findByRestaurant(restaurantId: string) {
    return this.prisma.video.findMany({
      where: {
        restaurantId,
        status: VideoStatus.APPROVED,
      },
    });
  }

  async create(restaurantId: string, data: {
    source: VideoSource;
    tiktokUrl?: string;
    videoUrl?: string;
    creatorHandle?: string;
  }) {
    return this.prisma.video.create({
      data: {
        restaurantId,
        ...data,
        status: VideoStatus.PENDING,
      },
    });
  }

  async approve(id: string) {
    return this.prisma.video.update({
      where: { id },
      data: { status: VideoStatus.APPROVED },
    });
  }

  async reject(id: string) {
    return this.prisma.video.update({
      where: { id },
      data: { status: VideoStatus.REJECTED },
    });
  }
}