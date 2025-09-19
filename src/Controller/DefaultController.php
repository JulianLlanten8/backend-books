<?php

namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class DefaultController
{
  #[Route('/', name: 'health_check')]
  public function index(): Response
  {
    return new Response('Backend is running ✅');
  }
}
