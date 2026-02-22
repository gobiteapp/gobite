import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findOne(id: string) {
    return this.prisma.user.findUnique({
      where: { id },
    });
  }

  async upsert(id: string, data: {
    email?: string;
    name?: string;
    avatarUrl?: string;
  }) {
    return this.prisma.user.upsert({
      where: { id },
      update: data,
      create: { id, ...data },
    });
  }

  async update(id: string, data: {
    name?: string;
    avatarUrl?: string;
  }) {
    return this.prisma.user.update({
      where: { id },
      data,
    });
  }
}