import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { TicketsService } from './tickets.service';
import { AuthGuard } from '../auth/auth.guard';

@Controller('tickets')
@UseGuards(AuthGuard)
export class TicketsController {
  constructor(private readonly ticketsService: TicketsService) {}

  @Get()
  findAll(@Request() req: any) {
    return this.ticketsService.findByUser(req.user.id);
  }

  @Post()
  create(@Request() req: any, @Body() body: {
    restaurantId: string;
    imageUrl: string;
  }) {
    return this.ticketsService.create(req.user.id, body);
  }
}