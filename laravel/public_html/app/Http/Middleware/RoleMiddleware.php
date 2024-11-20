<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class RoleMiddleware
{
    public function handle(Request $request, Closure $next, $role)
    {
        // Check if the authenticated user's role matches the required role
        if ($request->user()->role !== $role) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }
      
        return $next($request);
    }
}
