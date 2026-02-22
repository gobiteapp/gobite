import { Controller, Get, Put, Post, Body, UseGuards, Request } from '@nestjs/common';
import { UsersService } from './users.service';
import { AuthGuard } from '../auth/auth.guard';

@Controller('users')
@UseGuards(AuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  getProfile(@Request() req: any) {
    return this.usersService.findOne(req.user.id);
  }

  @Put('me')
  updateProfile(@Request() req: any, @Body() body: {
    name?: string;
    avatarUrl?: string;
  }) {
    return this.usersService.update(req.user.id, body);
  }

  @Post('sync')
  async sync(@Body() body: {
    email?: string;
    id: string;
    user_metadata?: { full_name?: string; avatar_url?: string };
  }) {
    console.log('Sync user called:', body);
    return this.usersService.upsert(body.id, {
      email: body.email,
      name: body.user_metadata?.full_name,
      avatarUrl: body.user_metadata?.avatar_url,
    });
  }
}