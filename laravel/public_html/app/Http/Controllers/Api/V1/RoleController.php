<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Resources\RoleCollection;
use App\Http\Resources\RoleResource;
use App\Models\Role;
use App\filters\Api\RoleFilter;
use App\Http\Controllers\Controller;
use App\Http\Requests\StoreRoleRequest;
use App\Http\Requests\UpdateRoleRequest;
use Illuminate\Http\Request;

class RoleController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $this->authorize('view-any', Role::class);
        $filter = new RoleFilter();
        $filterItems = $filter->transform($request);

        $includeUser = $request->query('includeUser');
        $role = Role::where($filterItems);

        if($includeUser){
            $role = $role->with('users');
        }

        return new RoleCollection($role->paginate()->appends($request->query()));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function store(StoreRoleRequest $request)
    {
        $this->authorize('create', Role::class);
        $validated = $request->validated();
        $role = Role::create($validated);
        return new RoleResource($role);
    }

    /**
     * Display the specified resource.
     */
    public function show(Role $role)
    {
        $this->authorize('view', $role);
        $includeUser = request()->query('includeUser');

        if($includeUser){
            return new RoleResource($role->loadMissing('users'));
        }

        return new RoleResource($role);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateRoleRequest $request, Role $role)
    {
        $this->authorize('update', $role);
        $validated = $request->validated();
        $role->update($validated);
        return new RoleResource($role);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Role $role)
    {
        $this->authorize('delete', $role);
        $role->delete();
        return response()->json(['message' => 'Role Deleted Successfully']);
    }
}