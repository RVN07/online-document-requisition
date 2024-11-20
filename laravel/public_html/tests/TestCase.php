<?php

namespace Tests;
use Mockery\Adapter\Phpunit\MockeryPHPUnitIntegration;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    use CreatesApplication, MockeryPHPUnitIntegration;
}
