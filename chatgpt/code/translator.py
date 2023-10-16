import torch
import os
import openai
import time

OPENAI_API_KEY= # Insert key
OPENAI_API_ORG= # Insert organization

class OpenAITranslator:
    def __init__(
        self,
        source_lang: str,
        target_lang: str,
        openai_model: str = "gpt-3.5-turbo"
    ):
        self.source_lang = source_lang
        self.target_lang = target_lang
        self.openai_model = openai_model

    def setup_key(self):
        """ Setup OpenAI API key. 
        """
        openai.organization = OPENAI_API_ORG
        openai.api_key = OPENAI_API_KEY

    def build_prompt(self, source: str, template_idx: int = 1):
        """ Builds a zero-shot prompt (str) to translate a given source sentence
        """

        prompt = f"Translate this sentence from {self.source_lang} to {self.target_lang}.\nSource:{source}\nTarget:"
        prompt_2 = f"Please provide the {self.target_lang} translation for this sentence: {source}"
        if (self.source_lang == "English"):
            prompt_3 = f"This is an {self.source_lang} to {self.target_lang} translation task, please provide the {self.target_lang} translation for this sentence: {source}"
        else:
            prompt_3 = f"This is a {self.source_lang} to {self.target_lang} translation task, please provide the {self.target_lang} translation for this sentence: {source}"
        prompt_4 = f"{self.source_lang}: {source}\n{self.target_lang}:"
        prompt_5 = f"Translate this sentence from {self.source_lang} to {self.target_lang} in 5 different ways.\nSource:{source}\n5 translations:"

        templates = {
            1: prompt,
            2: prompt_2,
            3: prompt_3,
            4: prompt_4,
            5: prompt_5,
        }

        return templates[template_idx]

    def translate(
        self,
        source: str,
        n_samples: int = 1,
        temperature: float = 1.0,
        top_p: float = 1.0,
        template_idx: int = 1,
        ts_prompt: bool = True,
        max_tokens=1024,
    ):
        """ Translates a given source sentence
        Returns:
        translations: list of *n_samples* translations
        total_tokens: total tokens (prompt + completion)
        prompt_tokens: prompt tokens
        failed_attempts: number of failed attempts
        """

        failed_attempts = 0
        prompt = self.build_prompt(source, template_idx)
        print('\nPrompt:', prompt)
        if self.openai_model=="gpt-3.5-turbo":
            if ts_prompt:
                messages = [
                    {"role": "system", "content": "You are a machine translation system."},
                    {"role": "user", "content": prompt},
                ]
            else:
                messages = [
                    {"role": "user", "content": prompt},
                ]

            print('n_samples', n_samples)
            count_try = 0
            while (count_try<15):
                try:
                    response = openai.ChatCompletion.create(
                        model=self.openai_model,
                        messages=messages,
                        temperature=temperature,
                        n=n_samples,
                        top_p=top_p,
                        max_tokens=max_tokens
                    )
                except:
                    print("problem!")
                    count_try += 1
                    failed_attempts += 1
                    time.sleep(60)
                    continue
                break
    
            total_tokens = response.usage.total_tokens
            prompt_tokens = response.usage.prompt_tokens
            translations = list([o.message.content for o in response.choices])
            print('\nTranslations:', translations)
        
        return translations, total_tokens, prompt_tokens, failed_attempts
