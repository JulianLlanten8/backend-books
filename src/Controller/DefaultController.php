<?php

namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\JsonResponse;

class DefaultController
{
  #[Route('/', name: 'health_check')]
  public function index(): Response
  {
    return new JsonResponse(['status' => 'ok']);
  }
}
