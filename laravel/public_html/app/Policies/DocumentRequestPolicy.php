<?php

namespace App\Policies;

use App\Models\DocumentRequest;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class DocumentRequestPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return true;
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, DocumentRequest $documentRequest): bool
    {
        return true;
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return true;
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, DocumentRequest $documentRequest): bool
    {
        return $user->role_id === 1;

    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, DocumentRequest $documentRequest): bool
    {
        return $user->isAdmin() || $user->isStaff();
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, DocumentRequest $documentRequest): bool
    {
        return true;
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, DocumentRequest $documentRequest): bool
    {
        return true;
    }
}
