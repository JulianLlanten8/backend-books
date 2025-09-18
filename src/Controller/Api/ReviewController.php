<?php

namespace App\Controller\Api;

use App\Entity\Review;
use App\Repository\BookRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;

class ReviewController extends AbstractController
{
    #[Route('/api/reviews', name: 'api_reviews_create', methods: ['POST'])]
    public function create(
        Request $request,
        BookRepository $bookRepository,
        EntityManagerInterface $emi,
        ValidatorInterface $validator
    ): JsonResponse {
        $data = json_decode($request->getContent(), true);

        // Validar datos básicos
        $bookId  = $data['book_id'] ?? null;
        $rating  = $data['rating'] ?? null;
        $comment = $data['comment'] ?? null;

        if (!$bookId || !$rating || !$comment) {
            return $this->json([
                'statusCode' => Response::HTTP_BAD_REQUEST,
                'message' => 'Faltan campos requeridos',
                'errors' => [
                    'book_id' => $bookId ? null : 'El campo book_id es requerido',
                    'rating' => $rating ? null : 'El campo rating es requerido',
                    'comment' => $comment ? null : 'El campo comment es requerido',
                ],
                'data' => [],
            ], Response::HTTP_BAD_REQUEST);
        }

        // Validar libro
        $book = $bookRepository->find($bookId);
        if (!$book) {
            return $this->json([
                'statusCode' => Response::HTTP_BAD_REQUEST,
                'message' => 'El libro no existe',
                'errors' => ['book_id' => "No existe el libro con id {$bookId}"],
                'data' => [],
            ], Response::HTTP_BAD_REQUEST);
        }

        // Crear reseña
        $review = new Review();
        $review->setBook($book);
        $review->setRating((int)$rating);
        $review->setComment($comment);
        $review->setCreatedAt(new \DateTimeImmutable());

        // Validaciones con Symfony Validator (ej: rating entre 1 y 5, comment no vacío)
        $errors = $validator->validate($review);
        if (count($errors) > 0) {
            $validationErrors = [];
            foreach ($errors as $error) {
                $validationErrors[$error->getPropertyPath()] = $error->getMessage();
            }

            return $this->json([
                'statusCode' => Response::HTTP_BAD_REQUEST,
                'message' => 'Errores de validación',
                'errors' => $validationErrors,
                'data' => [],
            ], Response::HTTP_BAD_REQUEST);
        }

        // Guardar en DB
        $emi->persist($review);
        $emi->flush();

        return $this->json([
            'statusCode' => Response::HTTP_CREATED,
            'message' => 'Reseña creada correctamente 🚀',
            'errors' => [],
            'data' => [
                'id' => $review->getId(),
                'created_at' => $review->getCreatedAt()->format('Y-m-d H:i:s'),
            ],
        ], Response::HTTP_CREATED);
    }
}
