import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class FavoritesService {
  constructor(private prisma: PrismaService) {}

  async findAll(userId: string) {
    return this.prisma.favorite.findMany({
      where: { userId },
      include: { restaurant: { include: { videos: true } } },
    });
  }

  async add(userId: string, restaurantId: string) {
    return this.prisma.favorite.create({
      data: { userId, restaurantId },
    });
  }

  async remove(userId: string, restaurantId: string) {
    return this.prisma.favorite.deleteMany({
      where: { userId, restaurantId },
    });
  }
}