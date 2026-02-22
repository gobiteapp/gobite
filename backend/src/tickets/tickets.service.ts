import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { TicketStatus } from '@prisma/client';

@Injectable()
export class TicketsService {
  constructor(private prisma: PrismaService) {}

  async findByUser(userId: string) {
    return this.prisma.ticket.findMany({
      where: { userId },
      include: { restaurant: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(userId: string, data: {
    restaurantId: string;
    imageUrl: string;
  }) {
    return this.prisma.ticket.create({
      data: {
        userId,
        restaurantId: data.restaurantId,
        imageUrl: data.imageUrl,
        status: TicketStatus.PENDING,
      },
    });
  }

  async updateAfterProcessing(id: string, data: {
    totalAmount?: number;
    peopleCount?: number;
    pricePerPerson?: number;
    visitedAt?: Date;
    status: TicketStatus;
  }) {
    return this.prisma.ticket.update({
      where: { id },
      data,
    });
  }
}